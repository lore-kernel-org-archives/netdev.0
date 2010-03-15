From: Julien Vehent <julien@linuxwall.info>
Subject: TBF parameters: overhead and linklayer =?UTF-8?Q?=3F?=
Date: Mon, 15 Mar 2010 17:42:39 +0100
Message-ID: <7370d7aa62d806f62f2a22b4095dd0ec@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:38615 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964965Ab0COQms convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 12:42:48 -0400
Received: from smtp3-g21.free.fr (localhost [127.0.0.1])
	by smtp3-g21.free.fr (Postfix) with ESMTP id 68451818183
	for <netdev@vger.kernel.org>; Mon, 15 Mar 2010 17:42:41 +0100 (CET)
Received: from ptichoun.linuxwall.info (ver44-2-82-242-128-240.fbx.proxad.net [82.242.128.240])
	by smtp3-g21.free.fr (Postfix) with ESMTP id 8A24481805F
	for <netdev@vger.kernel.org>; Mon, 15 Mar 2010 17:42:39 +0100 (CET)
Received: from ptichoun.linuxwall.info (localhost [127.0.0.1])
	by ptichoun.linuxwall.info (Postfix) with ESMTP id 49F64123044
	for <netdev@vger.kernel.org>; Mon, 15 Mar 2010 17:42:39 +0100 (CET)
Received: from njm.linuxwall.info (localhost [127.0.0.1])
	by ptichoun.linuxwall.info (Postfix) with ESMTP id 34659123040
	for <netdev@vger.kernel.org>; Mon, 15 Mar 2010 17:42:39 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

TC_TBF man page seem outdated (even in latest version of iproute2) and
doesn't explain what those two parameters do:

# tc qdisc add tbf help
Usage: ... tbf limit BYTES burst BYTES[/BYTES] rate KBPS [ mtu
BYTES[/BYTES] ]
        [ peakrate KBPS ] [ latency TIME ] [ overhead BYTES ] [ linklayer
TYPE ]


 - overhead ?
 - linklayer ?

Or did I miss something ?


Thanks,
Julien
