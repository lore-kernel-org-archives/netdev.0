From: Jeff Garzik <jgarzik@pobox.com>
Subject: So you thought sis190 was evil...
Date: Sun, 31 Aug 2003 21:18:41 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F529E71.20402@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Maillist netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It looks like the objectionable sis190 code was copied almost wholesale 
from r8169...   virt_to_bus, static descriptors, lack of cpu_to_leXX, 
and all.
