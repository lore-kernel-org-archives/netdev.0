From: Chetan Kumar <shivakumar.chetan@gmail.com>
Subject: Ingress policing
Date: Thu, 17 Feb 2005 22:30:28 +0530
Message-ID: <17fe83cb05021709002875e4ad@mail.gmail.com>
Reply-To: Chetan Kumar <shivakumar.chetan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi List,
It is really appreciable, if one of you can clarify me on this issue.
- Hide quoted text -

I was going thro the packet journey thro the network stack in Linux.
Now if I want enable ingress policing, it looks like packet
classification and policing should happen in netif_rx (i.e in the
interrupt context) before packet is queued on to the input queue am I
missing something.
