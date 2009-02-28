From: Andrew Grover <andy.grover@gmail.com>
Subject: ***SPAM*** Re: [ofa-general] [PATCH 0/26] Reliable Datagram Sockets
	(RDS), take 2
Date: Fri, 27 Feb 2009 17:53:19 -0800
Message-ID: <c0a09e5c0902271753n1a522647g6e7ac5465149c5a4@mail.gmail.com>
References: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
	<87myc73izx.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <87myc73izx.fsf@basil.nowhere.org>
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

On Fri, Feb 27, 2009 at 9:08 AM, Andi Kleen <andi@firstfloor.org> wrote:
>> This patchset against net-next adds support for RDS sockets. RDS is an
>> Oracle-originated protocol used to send IPC datagrams (up to 1MB)
>> reliably, and is used currently in Oracle RAC and Exadata products.
>
> Perhaps I missed it earlier, but what is the rationale for putting
> this as a socket type into the kernel? I assume they also work
> directly as implemented in user space using raw sockets or similar,
> don't they?

You want me to implement my fancy protocol in userspace???

Do I even get to write it in C or do I need to use Ruby?

Regards -- Andy
