From: Pete Zaitcev <zaitcev@redhat.com>
Subject: netdevice->generate_eui64
Date: Fri, 30 Jan 2004 17:03:16 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040130170316.789e8939.zaitcev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: zaitcev@redhat.com, <utz.bacher@de.ibm.com>, pavlic@de.ibm.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: schwidefsky@de.ibm.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, guys:

Does anyone know where I can find a patch to add dev->generate_eui64?
The qeth in 2.6 tree requires it to be built (with IPv6). I am talking
about a descendant of this patch:
 http://www.ussg.iu.edu/hypermail/linux/net/0303.0/0037.html

Thanks,
-- Pete
