From: "Tim Durack" <tdurack@gmail.com>
Subject: Re: r8169 ethernet bonding problems
Date: Mon, 30 Apr 2007 11:32:44 -0400
Message-ID: <9e246b4d0704300832p2f6b52cen5e71bdace70dc463@mail.gmail.com>
References: <9e246b4d0704180552q16b05017wd0d7041c3ce04f46@mail.gmail.com>
	 <20070418181333.GA2261@electric-eye.fr.zoreil.com>
	 <9e246b4d0704271353g105ecd62j4f35a6e9027ad590@mail.gmail.com>
	 <20070427220918.GB24358@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_4336_18615469.1177947164647"
Cc: netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.228]:52802 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423383AbXD3Pcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 11:32:46 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1568289wxd
        for <netdev@vger.kernel.org>; Mon, 30 Apr 2007 08:32:45 -0700 (PDT)
In-Reply-To: <20070427220918.GB24358@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_4336_18615469.1177947164647
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

> A tcpdump trace 1) before promiscuous mode 2) after promiscuous mode 3)
> after link failure (i.e. failover does not work) would be welcome.

See attached. Captures performed on bond0. Let me know if you prefer
captures against the physical member interfaces.

Tim:>

------=_Part_4336_18615469.1177947164647
Content-Type: application/octet-stream; name=promisc-off.pcap
Content-Transfer-Encoding: base64
X-Attachment-Id: f_f1538z90
Content-Disposition: attachment; filename="promisc-off.pcap"


------=_Part_4336_18615469.1177947164647
Content-Type: application/octet-stream; name=promisc-on.pcap
Content-Transfer-Encoding: base64
X-Attachment-Id: f_f1539d1z
Content-Disposition: attachment; filename="promisc-on.pcap"


------=_Part_4336_18615469.1177947164647
Content-Type: application/octet-stream; name=fail-eth1.pcap
Content-Transfer-Encoding: base64
X-Attachment-Id: f_f1539jxd
Content-Disposition: attachment; filename="fail-eth1.pcap"


------=_Part_4336_18615469.1177947164647
Content-Type: application/octet-stream; name=recover-eth1-1.pcap
Content-Transfer-Encoding: base64
X-Attachment-Id: f_f1539z90
Content-Disposition: attachment; filename="recover-eth1-1.pcap"


------=_Part_4336_18615469.1177947164647
Content-Type: application/octet-stream; name=fail-eth2-1.pcap
Content-Transfer-Encoding: base64
X-Attachment-Id: f_f153a61s
Content-Disposition: attachment; filename="fail-eth2-1.pcap"


------=_Part_4336_18615469.1177947164647
Content-Type: application/octet-stream; name=recover-eth2.pcap
Content-Transfer-Encoding: base64
X-Attachment-Id: f_f153ac2t
Content-Disposition: attachment; filename="recover-eth2.pcap"


------=_Part_4336_18615469.1177947164647--
