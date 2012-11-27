From: Jan Synacek <jsynacek@redhat.com>
Subject: [PATCH] ping,tracepath doc: Fix missing end tags.
Date: Tue, 27 Nov 2012 14:01:51 +0100
Message-ID: <1354021311-16760-1-git-send-email-jsynacek@redhat.com>
Cc: netdev@vger.kernel.org, Jan Synacek <jsynacek@redhat.com>
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60775 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753975Ab2K0NCC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2012 08:02:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jan Synacek <jsynacek@redhat.com>
---
 doc/ping.sgml      | 1 +
 doc/tracepath.sgml | 1 +
 2 files changed, 2 insertions(+)

diff --git a/doc/ping.sgml b/doc/ping.sgml
index f77276b..fb3c3ac 100644
--- a/doc/ping.sgml
+++ b/doc/ping.sgml
@@ -130,6 +130,7 @@ If value is zero, kernel allocates random flow label.
   <listitem><para>
 Show help.
   </para></listitem>
+ </varlistentry>
  <varlistentry>
   <term><option>-i <replaceable/interval/</option></term>
   <listitem><para>
diff --git a/doc/tracepath.sgml b/doc/tracepath.sgml
index 8da7cc0..19c3903 100644
--- a/doc/tracepath.sgml
+++ b/doc/tracepath.sgml
@@ -72,6 +72,7 @@ Sets the initial packet length to <replaceable/pktlen/ instead of
   <listitem><para>
 Sets the initial destination port to use.
   </para></listitem>
+ </varlistentry>
 </variablelist>
 </refsect1>
 
-- 
1.7.11.7
