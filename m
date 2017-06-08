From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Thu, 8 Jun 2017 19:00:07 +1000
Message-ID: <20170608190007.7140dcd1@canb.auug.org.au>
References: <20170608100858.4c1b18db@canb.auug.org.au>
        <20170608072220.GA778@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Hans de Goede <hdegoede@redhat.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170608072220.GA778@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Greg,

On Thu, 8 Jun 2017 09:22:20 +0200 Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:
>
> Looks good to me, thanks for this, I'll keep it around for when the
> merge window  happens.

Actually, that patch needs to go into the net tree before Dave asks
Linus to merge it - the net tree is based post v4.12-rc1 and contains
fixes for the current merge window.
-- 
Cheers,
Stephen Rothwell
