From: Andrew Grover <andy.grover@gmail.com>
Subject: [ofa-general] ***SPAM*** Re: [PATCH 02/21] RDS: Main header file
Date: Tue, 27 Jan 2009 11:23:04 -0800
Message-ID: <c0a09e5c0901271123k54010bew9efb6845c1d26bb@mail.gmail.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
	<1233022678-9259-3-git-send-email-andy.grover@oracle.com>
	<20090127130543.GD2646@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20090127130543.GD2646@ioremap.net>
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

On Tue, Jan 27, 2009 at 5:05 AM, Evgeniy Polyakov <zbr@ioremap.net> wrote:
>> +#define RDS_PORT     18634
>> +
>
> What will happen if some application already uses that port?

RDS errors out.

Yeah we're going to want to get an assigned port at some point, I guess.

Regards -- Andy
