From: "Roland Dreier" <rdreier@cisco.com>
Subject: Re: [PATCH 4 of 9] NetEffect 10Gb RNIC Driver:
 kernel driver header files
Date: Thu, 26 Oct 2006 17:33:44 -0700
Message-ID: <adafyda61hz.fsf@cisco.com>
References: <5E701717F2B2ED4EA60F87C8AA57B7CC064C9EBD@venom2>
 <20061026.171657.43852974.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	ggrundstrom@NetEffect.com,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20061026.171657.43852974.davem@davemloft.net> (David
 Miller's message of "Thu, 26 Oct 2006 17:16:57 -0700 (PDT)")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

 > I fear this is exactly the kind of stuff that we didn't want
 > to see start going into the kernel, and we've resisted the
 > TCP/IP stack offload stuff in the infiniband layer exactly
 > for this reason.

We're definitely not going to merge a second TCP stack in any form.

 - R.
