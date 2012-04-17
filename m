From: Serge Hallyn <serge.hallyn@canonical.com>
Subject: Re: [PATCH 00/12] add namespace support for netfilter protos
Date: Tue, 17 Apr 2012 09:35:26 -0500
Message-ID: <20120417143526.GB3213@sergelap>
References: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, ebiederm@xmission.com, dlezcano@fr.ibm.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Gao feng (gaofeng@cn.fujitsu.com):
> Currently the sysctl of netfilter proto is not isolated, so when 
> changing proto's sysctl in container will cause the host's sysctl 
> be changed too. it's not expected.
> 
> This patch set adds the namespace support for netfilter protos.

Thanks for doing this, Gao, sounds good.

(The set has gotten better scrutiny than I could give it, so I'll
wait until at least the next submission to attempt a review)

-serge
