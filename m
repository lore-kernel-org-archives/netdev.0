From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Problem using HTB
Date: Sat, 2 Apr 2005 23:36:42 +0200
Message-ID: <20050402213642.GO3086@postel.suug.ch>
References: <Pine.BSO.4.58.0504011240500.6284@pal.ece.iisc.ernet.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Abhishek Gupta <abhishek@pal.ece.iisc.ernet.in>
Content-Disposition: inline
In-Reply-To: <Pine.BSO.4.58.0504011240500.6284@pal.ece.iisc.ernet.in>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Abhishek Gupta <Pine.BSO.4.58.0504011240500.6284@pal.ece.iisc.ernet.in> 2005-04-01 15:10
> tc class add dev $DEV0 parent 2: classid 2:1 htb rate 100kbit burst 100 \
>    ceil 100kbit
> [...]
> I have configured for 100kbps, I am getting only 12kbps as the link speed.

Before I look into this, are you aware of 1kbps=8kbit?
