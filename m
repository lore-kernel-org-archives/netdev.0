From: Steven Young <sdyoung@vt220.org>
Subject: Re: [PATCH] arcnet: rimi: Fix device name in debug output
Date: Mon, 16 Apr 2012 13:20:28 +0100
Message-ID: <20120416122028.GA23830@vt220.org>
References: <20120415153220.GA11631@vt220.org>
 <alpine.LNX.2.00.1204161335420.16373@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1204161335420.16373@pobox.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 16, 2012 at 02:02:48PM +0200, Jiri Kosina wrote:
> I propose the minimalistic fix instead ... it'd be better to just drop the 
> BUGMSG() thing altogether and convert it to dev_printk(), but that'd be 
> larger revamp of the driver, and such effort is questionable for something 
> like Arcnet :)

  You're right, I'm not really interested in spending any amount of time on
ARCnet.  It's just something I noticed when I was booting a poorly-configured
kernel and thought I'd try a drive-by fix. :)

  Thanks for your time,
  Steve.
