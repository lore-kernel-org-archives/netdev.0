From: Alex Gartrell <alexgartrell@gmail.com>
Subject: Re: [PATCH,v2 net-next] ipvs: skb_orphan in case of forwarding
Date: Sun, 5 Jul 2015 15:19:27 -0700
Message-ID: <CALCkm3eyEbHpzfF1zk0OUnGaSf51=r9DmZs_2Xq4fTtOed3nNQ@mail.gmail.com>
References: <1436131706-1559824-1-git-send-email-agartrell@fb.com> <alpine.LFD.2.11.1507060105470.12815@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alex Gartrell <agartrell@fb.com>,
	Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>, kernel-team <kernel-team@fb.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.11.1507060105470.12815@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 5, 2015 at 3:13 PM, Julian Anastasov <ja@ssi.bg> wrote:
>         May be the patch fixes crashes? If yes, Simon
> should apply it for ipvs/net tree, otherwise after
> the merge window...

Yeah this is definitely a crash-fix and it's existed since at least 3.10.

-- 
Alex Gartrell <agartrell@fb.com>
