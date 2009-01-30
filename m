From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH v2 0/4] virtio_net: Add MAC and VLAN filtering
Date: Fri, 30 Jan 2009 15:33:51 +1030
Message-ID: <200901301533.52115.rusty@rustcorp.com.au>
References: <20090129230502.2672.87669.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090129230502.2672.87669.stgit@debian.lart>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 30 January 2009 09:35:02 Alex Williamson wrote:
> I'm not completely sure it's everything
> you're looking for Rusty, but it does seem cleaner.  Let me know if
> this is closer to what you're thinking.

Yep, now I'll go through the patches more carefully.

I know it's a pain to get this kind of nit-picking feedback, but it's an ordeal I force on everyone the first time they make a major contribution; it ensures the code "feels" consistent and means that when I read the code in future I'm not surprised by things which aren't *quite* how I expect.

Note that I tend to comment on *everything* where I would have done it differently.  So I expect you to argue at least half of them.

Thanks!
Rusty.
