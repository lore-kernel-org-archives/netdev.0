From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [patch net-next v3 07/17] rocker: introduce rocker switch driver
Date: Tue, 25 Nov 2014 16:13:08 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1C9FB50A@AcuExch.aculab.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-8-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"andy@greyhouse.net" <andy@greyhouse.net>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"azhou@nicira.com" <azhou@nicira.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
	"john.r.fastabend@intel.com" <john.r.fastabend@intel.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com
To: 'Jiri Pirko' <jiri@resnulli.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:44421 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751044AbaKYQOS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 11:14:18 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 19243-03 for <netdev@vger.kernel.org>;
 Tue, 25 Nov 2014 16:14:07 +0000 (GMT)
In-Reply-To: <1416911328-10979-8-git-send-email-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko
> 
> This patch introduces the first driver to benefit from the switchdev
> infrastructure and to implement newly introduced switch ndos. This is a
> driver for emulated switch chip implemented in qemu:
> https://github.com/sfeldma/qemu-rocker/

If this driver caller 'rocker' just to get the (bad) pun 'rocker switch'?
IMHO A more descriptive name would be a lot better.

	David
