From: "Bhanu Prakash Gollapudi" <bprakash@broadcom.com>
Subject: Re: linux-next: manual merge of the net tree with the scsi tree
Date: Wed, 29 Jun 2011 21:20:40 -0700
Message-ID: <4E0BF998.7030800@broadcom.com>
References: <20110630123325.43268067.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Vladislav Zolotarov" <vladz@broadcom.com>,
	"James Bottomley" <James.Bottomley@HansenPartnership.com>,
	mchan@broadcom.com
To: "Stephen Rothwell" <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110630123325.43268067.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/29/2011 7:33 PM, Stephen Rothwell wrote:
> Hi all,
>
> Today's linux-next merge of the net tree got conflicts in
> drivers/scsi/bnx2fc/bnx2fc.h and drivers/scsi/bnx2fc/bnx2fc_fcoe.c
> between commit 2382d2364a60 ("[SCSI] bnx2fc: Bumped version to 1.0.2")
> from the scsi tree and commit 619c5cb6885b ("New 7.0 FW: bnx2x, cnic,
> bnx2i, bnx2fc") from the net tree.
>
> I used the versions from the net tree as those version numbers were newer.
>
Stephen, can you please send the conflicts? Most probably you should 
have seen the conflicts w.r.t version number in bnx2fc.h and date in 
bnx2fc_fcoe.c.  If that is the case, the versions from net tree are good.

Thanks,
Bhanu
