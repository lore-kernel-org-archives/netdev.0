From: Susant Sahani <ssahani@gmail.com>
Subject: NF_STOLEN and re-insert in to IP stack
Date: Sat, 30 Jan 2010 14:28:47 +0530
Message-ID: <d81115a61001300058o65e0c079nf4d8469da024b53c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netfilter-devel@lists.netfilter.org, netfilter@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f182.google.com ([209.85.216.182]:58789 "EHLO
	mail-px0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751070Ab0A3I7I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2010 03:59:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Hi,

 I have yet to find any resource that answers this question. =A0If I
have  a kernel module that registers a callback with netfilter and
steals a  packet during the NF_IP_PRE_ROUTING stage, How can I
re-insert this  packet on the network stack, (before the ip routing
stage) .

 susant
