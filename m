From: Steve Grubb <sgrubb@redhat.com>
Subject: Re: [PATCH] XFRM: Display the audited SPI value in host byte order
Date: Wed, 12 Dec 2007 16:14:49 -0500
Message-ID: <200712121614.49626.sgrubb@redhat.com>
References: <20071212190542.20699.96051.stgit@flek.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-audit@redhat.com
Return-path: <linux-audit-bounces@redhat.com>
In-Reply-To: <20071212190542.20699.96051.stgit@flek.americas.hpqcorp.net>
Content-Disposition: inline
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Wednesday 12 December 2007 14:05:42 Paul Moore wrote:
> This patch corrects this inconsistency by writing the SPI values to the
> audit record in host byte order. 

Looks OK, to me, too.

-Steve
