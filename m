From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] isdn: Use kernel_{send,recv}msg instead of open
 coding
Date: Thu, 21 May 2009 15:14:43 -0700 (PDT)
Message-ID: <20090521.151443.79607416.davem@davemloft.net>
References: <20090521154126.GH5956@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, paul.moore@hp.com, netdev@vger.kernel.org,
	vanhoof@redhat.com, williams@redhat.com,
	linux-security-module@vger.kernel.org
To: acme@redhat.com
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090521154126.GH5956@ghostprotocols.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 21 May 2009 12:41:26 -0300

> Reducing the number of direct users of sock_{recv,send}msg.
> 
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Nice work, applied, thanks!
