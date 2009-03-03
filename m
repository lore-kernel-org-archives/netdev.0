From: Andrew Grover <andy.grover@gmail.com>
Subject: ***SPAM*** Re: [ofa-general] [PATCH 0/26] Reliable Datagram Sockets
	(RDS), take 2
Date: Tue, 3 Mar 2009 14:19:34 -0800
Message-ID: <c0a09e5c0903031419w2c90a82cn7e446dbe4f04891b@mail.gmail.com>
References: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
	<87myc73izx.fsf@basil.nowhere.org>
	<c0a09e5c0902271753n1a522647g6e7ac5465149c5a4@mail.gmail.com>
	<20090228055608.GB26292@one.firstfloor.org>
	<c0a09e5c0902281244u356acbecn98f37ac3abd5ebc0@mail.gmail.com>
	<20090228223653.GD26292@one.firstfloor.org>
	<c0a09e5c0902281658v48084cd8w8f95871395020e20@mail.gmail.com>
	<20090301015020.GH26292@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20090301015020.GH26292@one.firstfloor.org>
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

On Sat, Feb 28, 2009 at 5:50 PM, Andi Kleen <andi@firstfloor.org> wrote:
>> Higher load -> more time before a process runs -> rcvbuf overfills ->
>
> How can the rcvbuf overfill if the sender doesn't run?

rcvbuf overfill on the receiver-side.

-- Andy
