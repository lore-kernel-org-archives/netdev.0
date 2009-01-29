From: Andrew Grover <andy.grover@gmail.com>
Subject: [ofa-general] ***SPAM*** Re: [PATCH 01/21] RDS: Socket interface
Date: Thu, 29 Jan 2009 12:22:49 -0800
Message-ID: <c0a09e5c0901291222l30efc29fkcb62df18802155f4@mail.gmail.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
	<1233022678-9259-2-git-send-email-andy.grover@oracle.com>
	<20090126.201104.33429150.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20090126.201104.33429150.davem@davemloft.net>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 26, 2009 at 8:11 PM, David Miller <davem@davemloft.net> wrote:
> Socket family implementations do not belong under the
> infiniband subdirectory.
>
> Put it under net/ instead.
>
> I don't care what the interdependencies happen to be.

Roland, so you're ok with infiniband code under net/ ?

(or should I split it up??)

Thanks -- Regards -- Andy
