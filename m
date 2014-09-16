From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 5/5] rhashtable: Per bucket locks & expansion/shrinking
 in work queue
Date: Tue, 16 Sep 2014 14:22:30 +0100
Message-ID: <20140916132230.GA3831@casper.infradead.org>
References: <cover.1410782841.git.tgraf@suug.ch>
 <fe862eb8add076215918a0def9c3bd4fe8a104c7.1410782841.git.tgraf@suug.ch>
 <1410794580.7106.168.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, paulmck@linux.vnet.ibm.com,
	john.r.fastabend@intel.com, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1410794580.7106.168.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/15/14 at 08:23am, Eric Dumazet wrote:
> You need to roundup to next power of two.

Fixed, thanks!
