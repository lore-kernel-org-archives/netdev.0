From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Route cache performance under stress
Date: Mon, 9 Jun 2003 09:23:27 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030609092327.41899cb5.shemminger@osdl.org>
References: <20030608.225837.115923841.davem@redhat.com>
	<001801c32e50$57ef0750$4a00000a@badass>
	<20030608.232827.88487519.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: xerox@foonet.net, hadi@shell.cyberus.ca, sim@netnation.com,
	fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org,
	Robert.Olsson@data.slu.se
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030608.232827.88487519.davem@redhat.com>
List-Id: netdev.vger.kernel.org

Has anyone looked into using Judy array's to speedup the route cache. 
HP has opened it up (see http://sourceforge.net/projects/judy ) and it should
have better scaling for these type of attacks.
