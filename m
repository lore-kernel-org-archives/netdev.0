From: "??" <seong@etri.re.kr>
Subject: two net_device ?
Date: Fri, 2 Aug 2002 09:27:46 +0900
Sender: owner-netdev@oss.sgi.com
Message-ID: <004501c239bb$6ca70d30$21abfe81@seong>
References: <20020801133506.GA22073@serwus.bnet.pl> <200208011743.VAA07150@sex.inr.ac.ru> <20020801175204.GC17308@nic.nigdzie>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Return-path: <owner-netdev@oss.sgi.com>
To: <netdev@oss.sgi.com>
List-Id: netdev.vger.kernel.org

Hi, there.

I implemented 32 pseudo interface(eth1 ~ eth32) using a module.
When I up the interfaces using "ifconfig eth1 xx.xx.xx.xx" command,
there are two "eth1" interface. Before I up the interfaces, there is a "eth1" interface.
I can't find what thing goes wrong.

For test, I made just 2 pseudo interface using same mechanizm. then
above problem doesn't occur.

any suggestion, thanks..
I use 2.4.17 kernel.
