From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] soreuseport: add compat case for setsockopt
 SO_ATTACH_REUSEPORT_CBPF
Date: Mon, 06 Jun 2016 15:21:20 -0700 (PDT)
Message-ID: <20160606.152120.2108923624823325086.davem@davemloft.net>
References: <CAEfhGiwwvwf31Dj+s0zA0bpVAZ4x4=rLuU5g217u=wRrgm07Dg@mail.gmail.com>
	<20160603214002.GA58242@ast-mbp.thefacebook.com>
	<20160603214917.GA12557@ls3530.box>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, kraigatgoog@gmail.com,
	sergei.shtylyov@cogentembedded.com, ast@kernel.org,
	netdev@vger.kernel.org, linux-parisc@vger.kernel.org
To: deller@gmx.de
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <20160603214917.GA12557@ls3530.box>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Helge Deller <deller@gmx.de>
Date: Fri, 3 Jun 2016 23:49:17 +0200

> Commit 538950a1b752 ("soreuseport: setsockopt SO_ATTACH_REUSEPORT_[CE]BPF")
> missed to add the compat case for the SO_ATTACH_REUSEPORT_CBPF option.
> 
> Signed-off-by: Helge Deller <deller@gmx.de>

Applied.
