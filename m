From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: xtables:  Remove unnecessary initialization
 of struct ts_state
Date: Tue, 9 Sep 2014 12:02:40 +0200
Message-ID: <20140909100240.GA11567@salvia>
References: <1410162672-5040-1-git-send-email-prtvar.b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bojan Prtvar <prtvar.b@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1410162672-5040-1-git-send-email-prtvar.b@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 08, 2014 at 09:51:12AM +0200, Bojan Prtvar wrote:
> The skb_find_text() accepts uninitialized textsearch state variable.

Applied, thanks.

