From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH] Fix NUL (\0 or \x00) specification in string
Date: Wed, 7 Jan 2015 20:45:30 +0200
Message-ID: <CAHp75Vcu4ZBAbPdNFOwkbTjEdBNNXWrEpw1PM6iymYLFQp=7tw@mail.gmail.com>
References: <1420394722-20197-1-git-send-email-me@mortis.eu>
	<20150105150026.GG6114@twin.jikos.cz>
	<20150106192804.GL4806@salidar.dom.custoft.eu>
	<20150107122258.GG24104@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: dsterba@suse.cz, Giel van Schijndel <me@mortis.eu>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Armin Schindler <mac@melware.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	"open list:ISDN SUBSYSTEM" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150107122258.GG24104@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 7, 2015 at 2:22 PM, David Sterba <dsterba@suse.cz> wrote:
> On Tue, Jan 06, 2015 at 08:28:04PM +0100, Giel van Schijndel wrote:
>> On Mon, Jan 05, 2015 at 16:00:26 +0100, David Sterba wrote:
>> > I'm replying to all your recent patches here as they are fixing things
>> > reported in http://www.viva64.com/en/b/0299/ . I'ts a good practice to
>> > give the credit the reporter.
>> >
>> > The blogpost also contains analyses of the issues so it could help
>> > reviewing the patches.
>>
>> I guess you suggest I use a 'Reported-(at|by)' line?
>
> A link in the changelog would be enough IMHO.
>
>> Would something like the below suffice? I found similar log entries in the
>> commit log, e.g. bf3204cb, except that those add an e-mail address for
>> the reporters, which I don't think is necessary in this case.
>
> If you don't have the emails, then rather do not use reported-by.

Andrey Karpov <karpov@viva64.com>

But it requires an additional effort to get it.

-- 
With Best Regards,
Andy Shevchenko
