From: Mark Lord <kernel@start.ca>
Subject: Re: [GIT] Networking
Date: Thu, 21 Feb 2013 09:37:50 -0500
Message-ID: <5126313E.2060608@start.ca>
References: <20130220.170901.343210063003534302.davem@davemloft.net> <CA+55aFz=tzf9a-SY1CqCAxsqRDz=ebE69YoZ30at6kHeKKhsaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFz=tzf9a-SY1CqCAxsqRDz=ebE69YoZ30at6kHeKKhsaA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13-02-20 10:05 PM, Linus Torvalds wrote:
> On Wed, Feb 20, 2013 at 2:09 PM, David Miller <davem@davemloft.net> wrote:
>>
>> 15) Orphan and delete a bunch of pre-historic networking drivers from
>>     Paul Gortmaker.
> 
> Nooo.... You killed the 3c501 and 3c503 drivers! Snif.
> 
> I wonder if they still worked..

I hope they're not really dead, because we still use them in several machines here
as secondary interfaces for test rigs and whatnot.

It's a tad early to be nuking support for such widespread devices.
