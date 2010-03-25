From: David Miller <davem@davemloft.net>
Subject: Re: mmotm 2010-03-23 - IPv6 warnings...
Date: Thu, 25 Mar 2010 13:25:19 -0700 (PDT)
Message-ID: <20100325.132519.165189904.davem@davemloft.net>
References: <12096.1269481001@localhost>
	<20100324184226.3bf42d8f.akpm@linux-foundation.org>
	<4788.1269535530@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4788.1269535530@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Valdis.Kletnieks@vt.edu
Date: Thu, 25 Mar 2010 12:45:30 -0400

> On Wed, 24 Mar 2010 18:42:26 EDT, Andrew Morton said:
>> On Wed, 24 Mar 2010 21:36:41 -0400 Valdis.Kletnieks@vt.edu wrote:
>> 
>> > On Tue, 23 Mar 2010 15:34:59 PDT, akpm@linux-foundation.org said:
>> > > The mm-of-the-moment snapshot 2010-03-23-15-34 has been uploaded to
>> > > 
>> > >    http://userweb.kernel.org/~akpm/mmotm/
>> > 
>> > Seen in my dmesg.  It may be relevant that I'm at home, and my IPv6
>> > prefix arrives via a PPP VPN connection. This happened about 20-25 seconds
>> > after I launched pppd.
>> 
>> Yes, thanks, I get the same - it doesn't seem to break anything.  It
>> also happens some time after boot has completed.
> 
> Just doing an 'ifup eth0' on a network with IPv6 on it is sufficient.

I'm going to look into this more deeply tonight.
