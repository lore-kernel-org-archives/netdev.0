From: "Carlos Velasco" <carlosev@newipnet.com>
Subject: Re: Bug? ARP with wrong src IP address
Date: Thu, 24 Jul 2003 20:54:55 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307242054550080.00E3F4FF@192.168.128.16>
References: <Pine.LNX.4.44.0307241922270.10460-100000@l>
 <200307241836060226.006FACEB@192.168.128.16>
 <200307242011420101.00BC642D@192.168.128.16>
 <20030724113731.73e9bbf6.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: ja@ssi.bg, bdschuym@pandora.be, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20030724113731.73e9bbf6.davem@redhat.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 24/07/2003 at 11:37 David S. Miller wrote:

>> Question: _What would be the implications of applying my patch or
>similar to do linux behave like other OS?
>
>You'll break things for people who depend upon the
>way Linux currently behaves.

Well, really the question is: What are these situations exactly? IMHO... the patch is only changing the src ip address for arp requests on a few situations.

Regards,
Carlos Velasco
