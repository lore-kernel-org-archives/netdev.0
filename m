From: David Miller <davem@davemloft.net>
Subject: Re: [ 000/100] 3.8.3-stable review
Date: Wed, 13 Mar 2013 04:33:43 -0400 (EDT)
Message-ID: <20130313.043343.704615564539285477.davem@davemloft.net>
References: <20130312223122.884099393@linuxfoundation.org>
	<CAHsu+b9O+JG=v6FgAEG4KOVDGScFiZYQm_nqXOQ9NSae3D3hwA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	stable@vger.kernel.org, netdev@vger.kernel.org
To: a.heider@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHsu+b9O+JG=v6FgAEG4KOVDGScFiZYQm_nqXOQ9NSae3D3hwA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andre Heider <a.heider@gmail.com>
Date: Wed, 13 Mar 2013 09:02:46 +0100

> On Tue, Mar 12, 2013 at 11:30 PM, Greg Kroah-Hartman
> <gregkh@linuxfoundation.org> wrote:
>> This is the start of the stable review cycle for the 3.8.3 release.
>> There are 100 patches in this series, all will be posted as a response
>> to this one.  If anyone has any issues with these being applied, please
>> let me know.
> 
> Hi,
> 
> I'm missing a drivers/net/ethernet/atheros/atl1c patch, namely "atl1c:
> restore buffer state".
> In fact, it seems the whole netdev stable patch queue is missing:
> http://patchwork.ozlabs.org/bundle/davem/stable/?state=*
> 
> Unsure what the workflow is here, how are these supposed to make to stable?

I submit those patches at a time of my own choosing, and if you
read stable@vger.kernel.org you will see when I do that.

I let patches cook in Linus's tree for a week or so before submitting
to -stable so that any bugs in those changes are more likely to be
discovered before the change is in -stable too.
