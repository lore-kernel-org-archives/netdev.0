From: David Miller <davem@davemloft.net>
Subject: Re: tg3 driver upgrade (Linux 2.6.32 -> 3.2) breaks IBM
 Bladecenter SoL
Date: Tue, 02 Oct 2012 20:47:07 -0400 (EDT)
Message-ID: <20121002.204707.1362047307474271560.davem@davemloft.net>
References: <87626sd80j.fsf@lant.ki.iif.hu>
	<506B3B52.7080001@msgid.tls.msk.ru>
	<1349223432.16173.10.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mjt@tls.msk.ru, wferi@niif.hu, mchan@broadcom.com,
	netdev@vger.kernel.org, mcarlson@broadcom.com,
	grant.likely@secretlab.ca, rob.herring@calxeda.com,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349223432.16173.10.camel@deadeye.wl.decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <ben@decadent.org.uk>
Date: Wed, 03 Oct 2012 01:17:12 +0100

> On Tue, 2012-10-02 at 23:06 +0400, Michael Tokarev wrote:
>> On 02.10.2012 22:49, Ferenc Wagner wrote:
>> > "Michael Chan" <mchan@broadcom.com> writes:
>> >> These are the likely fixes:
>> >>
>> >> commit cf9ecf4b631f649a964fa611f1a5e8874f2a76db 
>> >> Author: Matt Carlson <mcarlson@broadcom.com>
>> >> Date: Mon Nov 28 09:41:03 2011 +0000
>> >>
>> >> tg3: Fix TSO CAP for 5704 devs w / ASF enabled
 ...
> The fix went into 3.3, so only 3.0 and 3.2 need it.
> 
> David, please can you include the above commit in your next batches for
> these stable series?

Done.
