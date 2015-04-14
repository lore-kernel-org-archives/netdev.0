From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 0/7 RFC] Netfilter/nf_tables ingress support
Date: Tue, 14 Apr 2015 22:05:32 +0200
Message-ID: <20150414220532.1ad69f24@redhat.com>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
	<20150410132205.GF23070@casper.infradead.org>
	<20150410200901.GB5968@salvia>
	<20150412.211421.1771298417488412635.davem@davemloft.net>
	<20150413201913.GD20275@acer.localdomain>
	<20150414090048.GA14022@casper.infradead.org>
	<20150414090559.GH22725@acer.localdomain>
	<20150414100846.GB14022@casper.infradead.org>
	<20150414101339.GC3004@acer.localdomain>
	<20150414103202.GC14022@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, Patrick McHardy <kaber@trash.net>,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150414103202.GC14022@casper.infradead.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 14 Apr 2015 11:32:02 +0100 Thomas Graf <tgraf@suug.ch> wrote:

> This is not a pledge specific to nft. I would like to see more
> numbers in general. We are putting APIs and frameworks in place that
> we can't remove afterwards without knowing how they really scale and
> perform.

I also vote for more performance numbers and measurements ;-)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
