From: Dmitry Kasatkin <dmitry.kasatkin@nokia.com>
Subject: [new release] Affix-0_99  --- Bluetooth Protocol Stack. OBEX and GUI available now.
Date: Sun, 14 Apr 2002 17:47:37 +0300
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3CB99689.7090105@nokia.com>
References: <3C500D09.4080206@nokia.com> <3C5AB093.5050405@nokia.com> <3C5E4991.6010707@nokia.com> <3C628D6A.2050900@nokia.com> <3C628DCF.40700@nokia.com> <3C6D25F6.4010905@nokia.com> <3C766511.5050808@nokia.com> <3C7F6C0C.6030204@nokia.com> <3C877AC7.8090008@nokia.com> <3C92111C.1070107@nokia.com> <3CA3A149.1080905@nokia.com> <3CAE2484.8090304@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: affix-devel@lists.sourceforge.net,
	Affix support <affix-support@lists.sourceforge.net>,
	linux-net <linux-net@vger.kernel.org>,
	linux-kernel@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Dmitry Kasatkin <dmitry.kasatkin@nokia.com>
List-Id: netdev.vger.kernel.org

Hi All.

Find new Affix release Affix-0_99 on http://affix.sourceforge.net

Profiles supported:
- Service Discovery.
- Serial Port.
- LAN Access.
- Dialup Networking.
- OBEX Object Push.
- OBEX File Transfer.
- PAN.

GUI environment A.F.E - Affix Frontend Environment available for use.
http://affix.sourceforge.net/afe
Link can be found on Affix WEB site in *Links* section.


CHANGES.

Version 0.99 [14.04.2002]
- [fix/changes] some SDP parts re-written.
- [changes] sockaddr_{hci,l2cap,rfcomm} repleaced by *sockaddr_affix*
	!NOTE: it requires to recompile and reinstall whole affix
- [new] *btctl* has now *prompt* (ftp) command - interactive shell &
	File Transfer Console (OBEX).
- [new] OBEX client now full featured (in ftp mode).
	commands: open, close, put, get, push, rm, cd, mkdir
- [new] Linux kernel 2.5.x supported (not well tested)
- [new] added new info to README (usage examples, commands explanation).


br, Dmitry



