From: "David S. Miller" <davem@redhat.com>
Subject: Re: Network oops
Date: Sun, 09 Jun 2002 21:32:24 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <ae1ak5$13p$2@main.gmane.org>
References: <200205202125.BAA03545@sex.inr.ac.ru>
	<3D0390E2.1B80ADEE@mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   ak@muc.de, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: george@mvista.com
In-Reply-To: <3D0390E2.1B80ADEE@mvista.com>
List-Id: netdev.vger.kernel.org


Also we need to know what network driver, if preemption is being
used (being from mvista I assume you are using preemption, and if
so make sure you have the preemption networking patches applied).
