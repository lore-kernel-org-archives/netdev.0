From: Kazunori MIyazawa <kazunori@miyazawa.org>
Subject: IPsec in linux-2.5.61
Date: Sun, 16 Feb 2003 15:52:38 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030216155238.5fb12777.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, davem@redhat.com, kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I'm Miyazawa@USAGI Project.
I'm sorry to sent mail from another address.

I saw linux-2.5.61 and I think some codes is from my patch.

If you think my opinion is proper, please add credits of changes

MIYAZAWA Kazunori @USAGI        :       support IPv6 IPsec


BTW, I'm trying to set the IPsec SA of IPv6, but the kernel returns
ENOBUF. Is there any changes around pfkey interface?

I'm using alexey's setkey in kametools.

I succeeded to set IPsec SA of IPv4 and Policies.

I prepare to send a patch to process the IPsec packet in IPv6 stack.

Best Regards,

--Kazunori Miyazawa (Yokogawa Electric Corporation)
