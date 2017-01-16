From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/3] tipc: improve interaction socket-link
Date: Mon, 16 Jan 2017 16:54:56 -0500 (EST)
Message-ID: <20170116.165456.1889846182858401216.davem@davemloft.net>
References: <1483457208-29033-1-git-send-email-jon.maloy@ericsson.com>
        <20170116.144514.1071967219363714348.davem@davemloft.net>
        <A2BAEFC30C8FD34388F02C9B3121859D225F44DE@eusaamb103.ericsson.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
        parthasarathy.bhuvaragan@ericsson.com, ying.xue@windriver.com,
        maloy@donjonn.com, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49498 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750996AbdAPVy6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 16:54:58 -0500
In-Reply-To: <A2BAEFC30C8FD34388F02C9B3121859D225F44DE@eusaamb103.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Mon, 16 Jan 2017 20:35:08 +0000

> 
> 
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>> On Behalf Of David Miller
>> Sent: Monday, 16 January, 2017 14:45
>> To: Jon Maloy <jon.maloy@ericsson.com>
>> Cc: netdev@vger.kernel.org; viro@zeniv.linux.org.uk; Parthasarathy Bhuvaragan
>> <parthasarathy.bhuvaragan@ericsson.com>; Ying Xue
>> <ying.xue@windriver.com>; maloy@donjonn.com; tipc-
>> discussion@lists.sourceforge.net
>> Subject: Re: [net-next 0/3] tipc: improve interaction socket-link
>> 
>> From: Jon Maloy <jon.maloy@ericsson.com>
>> Date: Tue,  3 Jan 2017 10:26:45 -0500
>> 
>> > We fix a very real starvation problem that may occur when a link
>> > encounters send buffer congestion. At the same time we make the
>> > interaction between the socket and link layer simpler and more
>> > consistent.
>> 
>> This doesn't apply to net-next, also the Date in your emails is 10 days
>> in the past.  What's going on here?
> 
> I don't know. This series was sent in on Jan 3rd, and applied by you the same day. Maybe the mail server decided to send you a duplicate?

If you look in the headers, they have "Received-by: " fields with
January 13th in the date.  So something pushed them out again.

Really strange...
