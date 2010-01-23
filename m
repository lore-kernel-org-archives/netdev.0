From: Metuki Sabhe <sabhe.metuki@gmail.com>
Subject: linux bridge problem
Date: Sat, 23 Jan 2010 16:41:40 +0200
Message-ID: <549992e51001230641n2e40d2co31573386e258a5cb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bridge@lists.linux-foundation.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

CC'ing netdev too:


 Hello,

 When I add interfaces to the bridge *after* I have "tcpdump -n -i br0"
 running on the bridge,
 my tcpdump don't see any communication. If I kill tcpdump and
 re-execute it *after* I added
 the interface to the bridge, it works just fine.

 The same behavior happens with my DHCP server (which listens only on
 my bridge interface);
 I need to re-execute (reset) it after I add the interface to the bridge.

 Is that normal ?

 Why does it happen ?

 What should I do ?

 It's a little awkward to reset my DHCP server every time I add a new
 interface to the bridge..

 Thanks,
 Sabhe
