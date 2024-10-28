import Buffer "mo:base/Buffer";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Float "mo:base/Float";

actor {
  type Gift = {
    id: Nat;
    recipient: Text;
    occasion: Text;
    description: Text;
    budget: Float;
    purchased: Bool;
    actualCost: ?Float;
    dueDate: Time.Time;
    notes: Text;
  };

  var gifts = Buffer.Buffer<Gift>(0);

  public func addGift(recipient: Text, occasion: Text, description: Text, 
    budget: Float, dueDate: Time.Time, notes: Text) : async Nat {
    let id = gifts.size();
    let newGift: Gift = {
      id;
      recipient;
      occasion;
      description;
      budget;
      purchased = false;
      actualCost = null;
      dueDate;
      notes;
    };
    gifts.add(newGift);
    id
  };

  public func markPurchased(id: Nat, actualCost: Float) : async Bool {
    if (id >= gifts.size()) return false;
    let gift = gifts.get(id);
    let updatedGift: Gift = {
      id = gift.id;
      recipient = gift.recipient;
      occasion = gift.occasion;
      description = gift.description;
      budget = gift.budget;
      purchased = true;
      actualCost = ?actualCost;
      dueDate = gift.dueDate;
      notes = gift.notes;
    };
    gifts.put(id, updatedGift);
    true
  };

  public query func getGiftsByRecipient(recipient: Text) : async [Gift] {
    let recipientGifts = Buffer.Buffer<Gift>(0);
    for (gift in gifts.vals()) {
      if (recipient == gift.recipient) {
        recipientGifts.add(gift);
      };
    };
    Buffer.toArray(recipientGifts)
  };

  public query func getUpcomingGifts() : async [Gift] {
    let upcoming = Buffer.Buffer<Gift>(0);
    let now = Time.now();
    
    for (gift in gifts.vals()) {
      if (not gift.purchased and gift.dueDate > now) {
        upcoming.add(gift);
      };
    };
    Buffer.toArray(upcoming)
  };

  public query func getBudgetSummary() : async {
    totalBudgeted: Float;
    totalSpent: Float;
    remainingBudget: Float;
    upcomingExpenses: Float;
  } {
    var totalBudgeted = 0.0;
    var totalSpent = 0.0;
    var upcomingExpenses = 0.0;

    for (gift in gifts.vals()) {
      totalBudgeted += gift.budget;
      switch (gift.actualCost) {
        case (?cost) { totalSpent += cost; };
        case (null) {
          if (not gift.purchased) {
            upcomingExpenses += gift.budget;
          };
        };
      };
    };

    {
      totalBudgeted;
      totalSpent;
      remainingBudget = totalBudgeted - totalSpent;
      upcomingExpenses;
    }
  };
}