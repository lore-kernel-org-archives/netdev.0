From: "David S. Miller" <davem@redhat.com>
Subject: Re: Info: NAPI performance at "low" loads
Date: Wed, 18 Sep 2002 14:22:50 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020918.142250.130847722.davem@redhat.com>
References: <1032381789.20498.151.camel@irongate.swansea.linux.org.uk>
	<20020918.134630.127509858.davem@redhat.com>
	<1032383727.20463.155.camel@irongate.swansea.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, hadi@cyberus.ca, akpm@digeo.com,
   manfred@colorfullife.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: alan@lxorguk.ukuu.org.uk
In-Reply-To: <1032383727.20463.155.camel@irongate.swansea.linux.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Alan Cox <alan@lxorguk.ukuu.org.uk>
   Date: 18 Sep 2002 22:15:27 +0100
   
   It doesnt matter what XFree86 is doing. Thats just to load the PCI bus
   and jam it up to prove the point. It'll change your inb timing
   
Understood.  Maybe a more accurate wording would be "a fixed minimum
timing".
