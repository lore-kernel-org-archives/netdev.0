From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 16:57:59 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030610.165759.78731321.davem@redhat.com>
References: <Pine.LNX.4.51.0306101725020.17226@ns.istop.com>
	<20030610.152020.59678979.davem@redhat.com>
	<Pine.LNX.4.51.0306101956520.7801@ns.istop.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, hadi@shell.cyberus.ca, xerox@foonet.net,
	sim@netnation.com, fw@deneb.enyo.de, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: ralph+d@istop.com, ralph@istop.com
In-Reply-To: <Pine.LNX.4.51.0306101956520.7801@ns.istop.com>
List-Id: netdev.vger.kernel.org

   From: Ralph Doncaster <ralph@istop.com>
   Date: Tue, 10 Jun 2003 19:58:47 -0400 (EDT)

   On Tue, 10 Jun 2003, David S. Miller wrote:
   
   > Every packet records a timestamp.
   
   I'm not aware of anything in IP routing that requires a timestamp for
   every packet.  To me it sounds like we could rip that out too.

Guess you never run tcpdump nor use packet schedulers.
