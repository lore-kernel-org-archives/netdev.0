From: Anil Gunturu <anil.gunturu@gmail.com>
Subject: kernel scalability
Date: Wed, 3 Nov 2004 23:17:01 -0800
Message-ID: <2f61ba570411032317438bd494@mail.gmail.com>
Reply-To: Anil Gunturu <anil.gunturu@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
We are porting linux kernel (2.4.18) for an embdded device that
supports a large number of logical interfaces (upto 200) and routes
(4000). There are only two physical ethernet interfaces, but we are
planning to add multiple ip addresses and routes using the "ip"
utility from iproute2 package. Just wondering if there are any
scalability issues in doing so as far as the kernel is concerned.
Thanks for your help,
-Anil
