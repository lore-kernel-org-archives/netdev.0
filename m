From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: POHMELFS high performance network filesystem. Cache coherency, transactions, parallels.
Date: Mon, 26 May 2008 11:07:09 +0400
Message-ID: <20080526070708.GB16366@2ka.mipt.ru>
References: <20080525134055.GA30630@2ka.mipt.ru> <483A0F3B.9060709@garzik.org> <20080526062204.GA16366@2ka.mipt.ru> <483A59D7.7020306@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <483A59D7.7020306@garzik.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 26, 2008 at 02:33:59AM -0400, Jeff Garzik (jeff@garzik.org) wrote:
> >No it should be cc4d281eb8d9a4d3a5610acf1558c327358f5725
> >Author: Evgeniy Polyakov johnpol@2ka.mipt.ru <zbr@gavana.yandex.ru>
> >Date:   Sun May 25 17:24:56 2008 +0400
> >
> >    Kconfig entries for cc group and debugging.
> >    
> >I used 'git push remote_repo' to push data after repository was create, 
> >probably I
> >should use 'git push --all remote_repo', please try again.
> 
> Nope.
> 
> Did you forget git-update-server-info, since your method is HTTP?

At least on server HEAD (refs/heads/master) points to
cc4d281eb8d9a4d3a5610acf1558c327358f5725

I tries git-update-server-info on client and pushed all again, but it
returned that everything is up-to-date.

-- 
	Evgeniy Polyakov
