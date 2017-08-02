From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] Adding Agile-SD TCP module and modifying Kconfig and
 Makefile
Date: Wed, 2 Aug 2017 14:09:15 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD004913E@AcuExch.aculab.com>
References: <stephen@networkplumber.org>
 <20170802044349.27582-1-mohamed.asnd@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "mohamed.a.alrshah@ieee.org" <mohamed.a.alrshah@ieee.org>
To: 'mohamedalrshah' <mohamed.asnd@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170802044349.27582-1-mohamed.asnd@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: mohamedalrshah
> Sent: 02 August 2017 05:44
> Published:
> Alrshah, M.A., Othman, M., Ali, B. and Hanapi, Z.M., 2015. Agile-SD: a Linux-based
> TCP congestion control algorithm for supporting high-speed and short-distance networks.
> Journal of Network and Computer Applications, 55, pp.181-190.
> 
> Agile-SD is a new loss-based and RTT-independent TCP congestion
> control algorithm designed to support high-speed and Short-Distance (SD)
> networks. It mainly contributes the agility factor mechanism, which allows
> Agile-SD to deal with small buffer sizes while reducing its sensitivity to
> packet loss. Due to the use of this mechanism, Agile-SD improves the
> throughput of TCP up to 50% compared to Cubic-TCP and Compound-TCP. Its
> performance was evaluated using the well-known NS2 simulator to measure
> the average throughput, loss ratio and fairness.
> 
> Agile-SD is designed and implemented by Mohamed A. Alrshah et al. (2015) as
> a Linux kernel module in the real Linux operating system (openSUSE 42.1 Leap),
> which is implemented at the Network, Parallel and Distributed Computing Laboratory,
> A2.10, second floor, Block A, Faculty of Computer Science and Information Technology,
> Universiti Putra Malaysia, over real PCs connected to the Internet for daily uses and
> evaluation purposes.
> 
> The main motivation behind Agile-SD is to support the short-distance networks such
> as local area networks and data center networks in order to increase the bandwidth
> utilization over high-speed networks. Moreover, Agile-SD is introduced in support
> of the open source community, where it can be used under the OpenGL agreement.

What a pile of bullshit ...

	David
