From: Wolfgang Denk <wd@denx.de>
Subject: Re: [PATCH 01/12] fs_enet: Use defines to set driver tunables.
Date: Thu, 07 May 2009 00:02:25 +0200
Message-ID: <20090506220225.A013583420E8@gemini.denx.de>
References: <1241640919-4650-1-git-send-email-wd@denx.de>
	<1241640919-4650-2-git-send-email-wd@denx.de>
	<fa686aa40905061335q3a3c4cc7r33d77df655100531@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Piotr Ziecik <kosmo@semihalf.com>,
	Detlev Zundel <dzu@denx.de>, netdev@vger.kernel.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-reply-to: <fa686aa40905061335q3a3c4cc7r33d77df655100531@mail.gmail.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Dear Grant,

In message <fa686aa40905061335q3a3c4cc7r33d77df655100531@mail.gmail.com> you wrote:
> On Wed, May 6, 2009 at 2:15 PM, Wolfgang Denk <wd@denx.de> wrote:
> > From: Piotr Ziecik <kosmo@semihalf.com>
> >
> > Signed-off-by: Piotr Ziecik <kosmo@semihalf.com>
> > Signed-off-by: Wolfgang Denk <wd@denx.de>
> > Cc: <netdev@vger.kernel.org>
> > Cc: Grant Likely <grant.likely@secretlab.ca>
> > Cc: John Rigby <jcrigby@gmail.com>
> 
> Not seeing much benefit to this patch, and the (non-existant) patch
> description doesn't really help me here either.

Please see next patch which then uses the ability to change the
defaults.

Best regards,

Wolfgang Denk

-- 
DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
Phone: (+49)-8142-66989-10 Fax: (+49)-8142-66989-80 Email: wd@denx.de
Program maintenance is an entropy-increasing process,  and  even  its
most skilfull execution only delays the subsidence of the system into
unfixable obsolescence.       - Fred Brooks, "The Mythical Man Month"
