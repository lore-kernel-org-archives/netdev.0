From: Willy Tarreau <w@1wt.eu>
Subject: Re: 2.6.32.66 tcp regression OOPs
Date: Mon, 1 Jun 2015 17:47:45 +0200
Message-ID: <20150601154745.GI28912@1wt.eu>
References: <6.2.5.6.2.20150531210751.0722ad10@binnacle.cx> <CAH6sp9O9sqKuamwF38JZLh+K2QKXNB7RRJ8cPtz+1h6MV7foYg@mail.gmail.com> <20150601074922.GA28740@1wt.eu> <6.2.5.6.2.20150601113107.07232e78@binnacle.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frans Klaver <fransklaver@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: starlight.2015q2@binnacle.cx
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6.2.5.6.2.20150601113107.07232e78@binnacle.cx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 01, 2015 at 11:32:19AM -0400, starlight.2015q2@binnacle.cx wrote:
> Hi,
> 
> I found the patch late yesterday and applied it.
> 
> Running fine now for 12 hours under active load.

Thank you.

> Recommend the patch be rolled into the tarball,
> or a notation added to the release page as this
> one has severe consequences.

I'll emit 2.6.32.67 with it. I didn't know it was that easy to trigger
it, and since feedback comes slowly on 2.6.32, I was waiting a bit for
more feedback before doing another one.

Thank you!
Willy
