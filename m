From: Steve Grubb <sgrubb@redhat.com>
Subject: Re: [PATCH] make xfrm_audit_log more generic
Date: Mon, 23 Jul 2007 14:11:39 -0400
Message-ID: <200707231411.40237.sgrubb@redhat.com>
References: <200707192242.l6JMglVk029578@faith.austin.ibm.com>
	<Line.LNX.4.64.0707192140350.12692@d.namei>
	<1185212957.15699.322.camel@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com,
	James Morris <jmorris@namei.org>, davem@davemloft.net
To: Joy Latten <latten@austin.ibm.com>
Return-path: <linux-audit-bounces@redhat.com>
In-Reply-To: <1185212957.15699.322.camel@faith.austin.ibm.com>
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

On Monday 23 July 2007 13:49:17 Joy Latten wrote:
> > Will this cause existing applications to break?
>
> Perhaps someone in audit list could help answer this.

Probably. Its better to take a new number and let the old ones sit idle.

-Steve
