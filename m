From: Patrick McHardy <kaber@trash.net>
Subject: Re: Hard freeze with 2.6.10-rc3 and QoS, worked fine with 2.6.9
Date: Wed, 08 Dec 2004 17:57:07 +0100
Message-ID: <41B73263.4040706@trash.net>
References: <1102380430.6103.6.camel@buffy>	 <20041206224441.628e7885.akpm@osdl.org>	 <1102422544.1088.98.camel@jzny.localdomain> <41B5E188.5050800@trash.net>	 <20041207170748.GF1371@postel.suug.ch> <41B5E722.2080600@trash.net>	 <20041207213053.6bb602c1.davem@davemloft.net> <1102507470.1051.27.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, tgraf@suug.ch, akpm@osdl.org,
        tomc@compaqnet.fr, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1102507470.1051.27.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

>I can almost guarantee that one or more of those tests i outlined would
>fail. So i would suggest a revert until the testing has been done.
>
Please be more specific than an "almost guarantee" that
"one or more tests" may fail when asking to revert a patch
that fixes an easily triggerable crash. For example, point
to the code that makes you think it might fail.
