From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH v3 00/17] netfilter: add namespace support for netfilter
 protos
Date: Mon, 21 May 2012 16:52:21 +0800
Message-ID: <4FBA0245.1000504@cn.fujitsu.com>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, serge.hallyn@canonical.com,
	ebiederm@xmission.com, dlezcano@fr.ibm.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B405=E6=9C=8814=E6=97=A5 16:52, Gao feng =E5=86=99=
=E9=81=93:
> Currently the sysctl of netfilter proto is not isolated, so when
> changing proto's sysctl in container will cause the host's sysctl
> be changed too. it's not expected.
>=20
> This patch set adds the namespace support for netfilter protos.

ping
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
