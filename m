From: Stephen Hemminger <shemminger@osdl.org>
Subject: Crash on shutdown (2.6.19-rc4)
Date: Wed, 01 Nov 2006 15:42:52 -0800
Message-ID: <454930FC.1090802@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020606080005070401030101"
Cc: netdev <netdev@vger.kernel.org>
To: netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020606080005070401030101
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

My desktop machine (Fedora Core 6) crashed on during shutdown when 
running latest
2.6.19-rc4 kernel. Machine is UP Amd64.

It looks like a null dereference in ip_conntrack. See attached screenshot.

--------------020606080005070401030101--
