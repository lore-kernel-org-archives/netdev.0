From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 00/11] default maximal number of RSS queues in
 mq drivers
Date: Sun, 1 Jul 2012 18:01:16 +0300
Message-ID: <4FF0663C.1070306@mellanox.com>
References: <1341148740-7375-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<eilong@broadcom.com>, Divy Le Ray <divy@chelsio.com>,
	Jon Mason <jdmason@kudzu.us>,
	"Anirban Chakraborty" <anirban.chakraborty@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Ron Mercer <ron.mercer@qlogic.com>,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>,
	Jon Mason <mason@myri.com>,
	"Andrew Gallatin" <gallatin@myri.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	"Subbu Seetharaman" <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:59589 "HELO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932401Ab2GAPBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 11:01:37 -0400
In-Reply-To: <1341148740-7375-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/1/2012 4:18 PM, Yuval Mintz wrote:
> Different vendors support different number of RSS queues by default. Today,
> there exists an ethtool API through which users can change the number of
> channels their driver supports; This enables us to pursue the goal of using
> a default number of RSS queues in various multi-queue drivers.

Yuval,

I assume this posting is actually v3 of "[RFC net-next (v2) 00/14] 
default maximal number of RSS queues in mq drivers" see 
http://marc.info/?l=linux-netdev&m=134062509310404&w=2?

correct? so what has been changed along v0/v1/v2 --> v3?  It would be 
very helpful to follow
if you make sure to mark the patches that makes Vn with "PATCH net-next 
Vn" and specify the changes
from Vn-1, Vn-2...V1, V0.

Or.
