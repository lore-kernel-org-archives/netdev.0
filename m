From: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at skb_copy_and_csum_dev
Date: Fri, 27 Aug 2010 11:44:51 +0300
Message-ID: <4C777B03.9060203@fs.uni-ruse.bg>
References: <20100820193835.GA6025@del.dom.local>	 <20100821074742.GA2367@del.dom.local>	 <1282377058.2636.12.camel@edumazet-laptop>	 <20100821080735.GA2409@del.dom.local> <4C725FCB.2000304@fs.uni-ruse.bg>	 <20100823124736.GA16966@ff.dom.local>	 <1282568443.2486.34.camel@edumazet-laptop>	 <20100823131056.GA19160@ff.dom.local> <4C727B06.2060002@fs.uni-ruse.bg>	 <4C72802D.8090405@fs.uni-ruse.bg> <20100823141437.GA2282@del.dom.local>	 <4C734FB5.1090702@fs.uni-ruse.bg>	 <1282626102.2378.1351.camel@edumazet-laptop>	 <4C738636.4000107@fs.uni-ruse.bg>  <4C73C8DF.4060601@fs.uni-ruse.bg> <1282662532.2477.248.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [83.228.35.12] ([83.228.35.12]:38694 "EHLO fs.ru.acad.bg"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752699Ab0H0Iox (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Aug 2010 04:44:53 -0400
In-Reply-To: <1282662532.2477.248.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current status refresh:

Just tried 2.6.35.4, but without luck.

See the oops at http://picpaste.com/8240d73e92bd2ba25a9b4019010fcabf.jpg

Eric Dumazet and I are continuing to try and find a solution for my
problem via private email.

Thanks,
Plamen
