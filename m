From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: [ethtool] ethtool: Fix FSF address in file headers
Date: Tue, 17 Dec 2013 13:33:15 -0800
Message-ID: <CAEuXFEz7pY0YM7Q9V0nBA3W1YQ9A85ST5cSuuVm02xgf0fAU-g@mail.gmail.com>
References: <1386358320-26283-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bhutchings@solarflare.com, NetDEV list <netdev@vger.kernel.org>,
	gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f42.google.com ([209.85.214.42]:36576 "EHLO
	mail-bk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475Ab3LQVdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 16:33:16 -0500
Received: by mail-bk0-f42.google.com with SMTP id w11so3061604bkz.29
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 13:33:15 -0800 (PST)
In-Reply-To: <1386358320-26283-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 6, 2013 at 11:32 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> - Copyright (C) 1989, 1991 Free Software Foundation, Inc.
> -     59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
> + Copyright (C) 1989, 1991 Free Software Foundation, Inc. <http://fsf.org/>
>   Everyone is permitted to copy and distribute verbatim copies
>   of this license document, but changing it is not allowed.
>
> @@ -304,8 +303,7 @@ the "copyright" line and a pointer to where the full notice is found.
>      GNU General Public License for more details.
>
>      You should have received a copy of the GNU General Public License
> -    along with this program; if not, write to the Free Software
> -    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
> +    along with this program; if not, see <http://www.gnu.org/licenses/>.

Unless I am mistaken, the GPL expressly forbids making changes to the
license.  I'm not sure we can make this change.

quote:
 | Everyone is permitted to copy and distribute verbatim copies
 | of this license document, but changing it is not allowed.
