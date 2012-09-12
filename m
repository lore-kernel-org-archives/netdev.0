From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [V3 PATCH 9/9] cxgb4vf: Chelsio FCoE offload driver submission (header compatibility fixes).
Date: Wed, 12 Sep 2012 09:52:23 -0700
Message-ID: <m2har3yyig.fsf@firstfloor.org>
References: <1347374347-3852-10-git-send-email-naresh@chelsio.com>
	<20120911.133321.282568248903907762.davem@davemloft.net>
	<50501F1A.6040905@chelsio.com>
	<20120912.014746.636228439025755624.davem@davemloft.net>
	<50502B3A.6080803@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"JBottomley\@parallels.com" <JBottomley@parallels.com>,
	"linux-scsi\@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	Dimitrios Michailidis <dm@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Chethan Seshadri <chethan@chelsio.com>
To: Naresh Kumar Inna <naresh@chelsio.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <50502B3A.6080803@chelsio.com> (Naresh Kumar Inna's message of
	"Wed, 12 Sep 2012 11:57:06 +0530")
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Naresh Kumar Inna <naresh@chelsio.com> writes:
>
> OK, I think I should be able to arrange the patch set to fulfill that
> requirement. I was under the impression it was fine for new drivers to
> split patches in this fashion, since they go as a single commit, sorry
> about that.

What they normally do then is to add the Kconfig or Makefile entry
only in the end, so it cannot build before.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only
