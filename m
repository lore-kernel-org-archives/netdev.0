From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/2] man/send(2): add EPERM to the list of possible errors
Date: Tue, 26 Mar 2013 11:48:33 +0100
Message-ID: <20130326104833.GA5331@localhost>
References: <1363675513.4767.6.camel@nexus>
 <51515E5E.7020309@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Kerrisk <mtk.manpages@gmail.com>,
	linux-man@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Hirotaka Sasaki <sasaki.hirotaka@lab.ntt.co.jp>
To: Fernando Luis Vazquez Cao <fernando_b1@lab.ntt.co.jp>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51515E5E.7020309@lab.ntt.co.jp>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 26, 2013 at 05:37:50PM +0900, Fernando Luis Vazquez Cao wrote:
> Hi Michael,
> 
> Do you see any problem with these two patches?

Please, hold on with the second patch.

I'd like to find a possible solution for the EPERM problem that we've
been discussing. It requires some rework and performance evaluation.
