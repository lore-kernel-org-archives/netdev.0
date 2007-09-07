From: Jeff Garzik <jeff@garzik.org>
Subject: Re: request for information about the "ath5k" licensing
Date: Fri, 07 Sep 2007 19:42:36 -0400
Message-ID: <46E1E1EC.4000405@garzik.org>
References: <20070905151823.GA1384@slim.vantronix.net> <200709051835.33572.mb@bu3sch.de> <43e72e890709051000m74252604paff3eb1651f55d22@mail.gmail.com> <20070907064730.GA15001@slim.vantronix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@gmail.com>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, jirislaby@gmail.com,
	moglen@softwarefreedom.org
To: Reyk Floeter <reyk@openbsd.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753572AbXIGXm6@vger.kernel.org>
In-Reply-To: <20070907064730.GA15001@slim.vantronix.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reyk Floeter wrote:
> I'm still waiting for an answer. Your process is taking too long.


Speaking as a person through which these changes flow upstream into the 
official kernel (ath5k maintainers -> linville -> me -> linus)...


The most important thing for today is that no ath5k stuff has been 
committed (nor has it ever been).


I would rather take it slow and make sure everybody is happy.  There is 
nothing upstream, and so, there is no need to rush and correct something.

Collectively, this is just growing pains.  Everyone is breaking new 
ground, trying to figure out how to best support atheros stuff on Linux. 
  There are new tools to deal with (svn? git? flavor of the day?:)), new 
licenses with new ramifications to consider, a new wireless stack to 
deal with.

What you are witnessing is but a small part of the chaos as everyone 
tackles these chores simultaneously.

	Jeff
